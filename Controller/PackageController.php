<?php

namespace Packagist\WebBundle\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Security\Core\Exception\AccessDeniedException;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Template;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;

use Packagist\WebBundle\Entity\Package;
use Packagist\WebBundle\Package\Updater;

use Composer\IO\NullIO;
use Composer\Factory;
use Composer\Repository\VcsRepository;

class PackageController extends Controller
{
    /**
     * @Template()
     * @Route(
     *     "/packages/{name}/edit",
     *     name="edit_package",
     *     requirements={"name"="[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+?"}
     * )
     */
    public function editAction(Request $req, $name)
    {
        $packages = $this->getDoctrine()->getRepository('PackagistWebBundle:Package');
        $package = $packages->findOneByName($name);

        if (!$package) {
            throw $this->createNotFoundException("The requested package, $name, could not be found.");
        }

        if (!$package->getMaintainers()->contains($this->getUser()) && !$this->get('security.context')->isGranted('ROLE_UPDATE_PACKAGES')) {
            throw new AccessDeniedException;
        }

        $form = $this->createFormBuilder($package)
            ->add("repository", "text")
            ->getForm();

        if ('POST' === $req->getMethod()) {
            $package->setEntityRepository($packages);

            $form->bindRequest($req);

            if ($this->get("validator")->validateProperty($package, "repository")) {
                $em = $this->getDoctrine()->getEntityManager();
                $em->persist($package);
                $em->flush();

                $this->updatePackage($package);

                $this->get("session")->setFlash("notice", "Changes saved.");

                return $this->redirect(
                    $this->generateUrl("view_package", array("name" => $package->getName()))
                );
            }
        }

        return array(
            "package" => $package, "form" => $form->createView()
        );
    }

    private function updatePackage(Package $package)
    {
        $doctrine = $this->getDoctrine();

        set_time_limit(3600);
        $updater = $this->get('packagist.package_updater');

        $config = Factory::createConfig();
        $repository = new VcsRepository(array('url' => $package->getRepository()), new NullIO, $config);
        $updater->update($package, $repository, Updater::UPDATE_TAGS);
    }
}

